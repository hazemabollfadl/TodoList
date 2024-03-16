import UIKit
import CoreData

class TodoListVC: UITableViewController  {
    
    var itemArray:[Item]=[]
    
    var selectedCategory:Categories? {
        //Runs When a variable gets a new value
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textResult = UITextField()
        
        let alert=UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert )
        
        let action=UIAlertAction(title: "Add Item", style: .default) { action in
            
            //what happens when the user clicks add item
            if textResult.text==""{
                let alert=UIAlertController(title: "Warning", message: "No Items Were Added", preferredStyle: .alert)
                let action=UIAlertAction(title: "Ok", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }else{
                //stores added item in the array of itemArray
                
                let newItem = Item(context: self.context)
                newItem.name = textResult.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newItem)
                
                self.saveItems()
                
            }
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder="Create New Item"
            textResult=alertTextField
        }
        
        present(alert, animated: true)
    }
}

//MARK: - UITableViewDataSources
extension TodoListVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell=tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        let cell=UITableViewCell(style: .default , reuseIdentifier: "ToDoItemCell")
        
        
        let itemList = itemArray[indexPath.row]
        
        cell.textLabel?.text=itemList.name
        
        cell.accessoryType = itemList.done ? .checkmark : .none
        
        return cell
        
    }
    
}

//MARK: - UITableViewDelegate
extension TodoListVC{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //Sets a specific value for the given key name which is the attribute or field
        //itemArray[indexPath.row].setValue("completed", forKey: "name")]
        
        //        context.delete(itemArray[indexPath.row])
        //        itemArray.remove(at: indexPath.row)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - Model manipulation methods
extension TodoListVC{
    
    func saveItems(){
        
        do{
            try context.save()
        }catch{
            print("Error saving context\(error)")
        }
        
        //Reloads the tableView
        tableView.reloadData()
    }
    
    
    //NSFetchRequest object with declared type(Item)
    func loadItems(with request: NSFetchRequest<Item>=Item.fetchRequest(),_ predicate:NSPredicate? = nil){
        
        //Filters the incoming data based on if the parent category matches the sleceted category
        let categoryPredicate = NSPredicate(format: "parentCategory.title MATCHES %@", selectedCategory!.title!)
        
        
        if let safePredicate=predicate{
            
            //Making Compound(Multiple) predicates to be added to the request
            let compoundPredicate=NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,safePredicate])
            request.predicate=compoundPredicate
            
        }else{
            request.predicate=categoryPredicate
        }
        
        
        do{
            //access context and try to fetch the data specified by "request" and save it to the itemArray
            itemArray =  try context.fetch(request)
        }catch{
            print("Error couldn't fetch the Data from context: \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension TodoListVC:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Item>=Item.fetchRequest()
        
        
        //Filters the incoming data based on if the text typed matches the sleceted item regardless of caps
        let predicate=NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.predicate=predicate
        
        //Sorts the Data list asscending based on the 'name'  attribute
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors=[sortDescriptor]
        
        loadItems(with: request, predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            loadItems()
            
            //Tells the search bar to go to the background and make the keyboard dissappears
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

